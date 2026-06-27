#!/usr/bin/env node
/**
 * Forge SWEXP autograder (Module 08 — Platform Engineering & Containerization, bats harness).
 * Runs each exercise's bats tests, plus a shell-syntax gate (`bash -n`),
 * then prints a per-exercise score and writes a Markdown report for CI.
 *
 * Each exercise is a folder under labs/ or assignments/ containing
 * `solution.sh` (the student edits) and `tests/*.bats` (the spec).
 * No answer keys are shipped.
 */
import { execSync } from 'node:child_process';
import { readdirSync, existsSync, writeFileSync, appendFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const BATS = join('node_modules', '.bin', 'bats');

function listExercises() {
  const out = [];
  for (const group of ['labs', 'assignments']) {
    if (!existsSync(group)) continue;
    for (const name of readdirSync(group).sort()) {
      const dir = join(group, name);
      if (statSync(dir).isDirectory() && existsSync(join(dir, 'tests'))) {
        out.push({ key: `${group}/${name}`, dir });
      }
    }
  }
  return out;
}

function runBats(testsDir) {
  let out = '';
  try {
    out = execSync(`${BATS} --formatter tap "${testsDir}"`, { stdio: ['ignore', 'pipe', 'pipe'] }).toString();
  } catch (e) {
    out = `${e.stdout ?? ''}${e.stderr ?? ''}`;
  }
  let passed = 0;
  let total = 0;
  for (const line of out.split('\n')) {
    if (/^ok\b/.test(line)) { passed++; total++; }
    else if (/^not ok\b/.test(line)) { total++; }
  }
  return { passed, total };
}

function syntaxGate() {
  // Not every exercise ships a solution.sh in this module (many author a
  // Dockerfile / compose / manifest instead). nullglob makes the gate tolerate
  // a folder with no solution.sh — it only syntax-checks the ones present.
  try {
    execSync(
      'shopt -s nullglob; files=(labs/*/solution.sh assignments/*/solution.sh); [ ${#files[@]} -eq 0 ] || bash -n "${files[@]}"',
      { stdio: ['ignore', 'pipe', 'pipe'], shell: '/bin/bash' },
    );
    return { ok: true };
  } catch {
    return { ok: false };
  }
}

const exercises = listExercises();
const tally = exercises.map((e) => ({ ...e, ...runBats(join(e.dir, 'tests')) }));
const gate = syntaxGate();

const passed = tally.reduce((s, t) => s + t.passed, 0);
const total = tally.reduce((s, t) => s + t.total, 0);
const pct = total ? Math.round((passed / total) * 100) : 0;
const complete = passed === total && total > 0 && gate.ok;

const rows = tally.map((t) => {
  const mark = t.total > 0 && t.passed === t.total ? '✅' : '❌';
  return `| \`${t.key}\` | ${t.passed}/${t.total} | ${mark} |`;
});

const md = [
  `## Forge SWEXP — Module 08 autograde`,
  ``,
  `**Score: ${passed}/${total} tests (${pct}%)**  ·  Shell syntax: ${gate.ok ? '✅ clean' : '❌ errors'}`,
  ``,
  `| Exercise | Tests | Status |`,
  `| --- | --- | --- |`,
  ...rows,
  ``,
  complete
    ? `🎉 **All exercises complete and every script parses cleanly.**`
    : `Keep going — open each exercise folder, complete the \`# TODO\`s in its starter (a \`Dockerfile\`, \`docker-compose.yml\`, \`ci.yml\`, \`deployment.yml\`, or \`solution.sh\`), and run \`npm test\`. The \`tests/*.bats\` files are the spec.`,
].join('\n');

writeFileSync('grade-report.md', md + '\n');
console.log('\n' + md + '\n');
if (process.env.GITHUB_STEP_SUMMARY) appendFileSync(process.env.GITHUB_STEP_SUMMARY, md + '\n');

process.exit(complete ? 0 : 1);
