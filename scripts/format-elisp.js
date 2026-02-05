#!/usr/bin/env node

const { glob } = require('glob');
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Configuration
const DOOM_DIR = process.cwd();
const CHECK_ONLY = process.argv.includes('--check');

// ANSI colors for output
const colors = {
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  blue: '\x1b[34m',
  reset: '\x1b[0m',
  bold: '\x1b[1m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function formatElispFile(filePath) {
  const absolutePath = path.resolve(filePath);

  // Create a temporary backup for comparison if in check mode
  let originalContent = '';
  if (CHECK_ONLY) {
    originalContent = fs.readFileSync(absolutePath, 'utf8');
  }

  // Emacs batch command to format the file
  const emacsCommand = `emacs --batch --no-init-file \\
    --eval "(require 'editorconfig nil t)" \\
    --eval "(when (featurep 'editorconfig) (editorconfig-mode 1))" \\
    --eval "(find-file \\"${absolutePath}\\")" \\
    --eval "(when (featurep 'editorconfig) (editorconfig-apply))" \\
    --eval "(lisp-indent-region (point-min) (point-max))" \\
    --eval "(delete-trailing-whitespace)" \\
    --eval "(when (not (eq (char-before (point-max)) ?\\n)) (goto-char (point-max)) (insert \\"\\n\\"))" \\
    --eval "(save-buffer)"`;

  try {
    execSync(emacsCommand, {
      stdio: CHECK_ONLY ? 'pipe' : 'inherit',
      timeout: 30000
    });

    if (CHECK_ONLY) {
      const newContent = fs.readFileSync(absolutePath, 'utf8');
      const needsFormatting = originalContent !== newContent;

      // Restore original content in check mode
      fs.writeFileSync(absolutePath, originalContent);

      return { success: true, needsFormatting, path: filePath };
    }

    return { success: true, needsFormatting: false, path: filePath };
  } catch (error) {
    return { success: false, error: error.message, path: filePath };
  }
}

async function main() {
  log(`${colors.bold}Emacs Lisp Formatter${colors.reset}`, 'blue');
  log(`Working directory: ${DOOM_DIR}`, 'blue');
  log(`Mode: ${CHECK_ONLY ? 'Check only (dry-run)' : 'Format files'}`, 'blue');
  console.log('');

  try {
    // Find all .el files
    const files = await glob('**/*.el', {
      cwd: DOOM_DIR,
      ignore: ['node_modules/**', '.git/**']
    });

    if (files.length === 0) {
      log('No .el files found.', 'yellow');
      process.exit(0);
    }

    log(`Found ${files.length} Emacs Lisp files`, 'green');
    console.log('');

    const results = [];
    let formattedCount = 0;
    let errorCount = 0;
    let needsFormattingCount = 0;

    // Process each file
    for (const file of files) {
      const result = formatElispFile(file);
      results.push(result);

      if (result.success) {
        if (CHECK_ONLY) {
          if (result.needsFormatting) {
            log(`✗ ${file} - needs formatting`, 'yellow');
            needsFormattingCount++;
          } else {
            log(`✓ ${file} - already formatted`, 'green');
          }
        } else {
          log(`✓ ${file} - formatted`, 'green');
          formattedCount++;
        }
      } else {
        log(`✗ ${file} - error: ${result.error}`, 'red');
        errorCount++;
      }
    }

    // Summary
    console.log('');
    log(`${colors.bold}Summary:${colors.reset}`, 'blue');

    if (CHECK_ONLY) {
      log(`Files checked: ${files.length}`, 'blue');
      log(`Files needing formatting: ${needsFormattingCount}`, needsFormattingCount > 0 ? 'yellow' : 'green');
      log(`Errors: ${errorCount}`, errorCount > 0 ? 'red' : 'green');

      if (needsFormattingCount > 0) {
        console.log('');
        log('Run "npm run format" to format the files that need formatting.', 'blue');
        process.exit(1);
      }
    } else {
      log(`Files processed: ${files.length}`, 'blue');
      log(`Files formatted: ${formattedCount}`, 'green');
      log(`Errors: ${errorCount}`, errorCount > 0 ? 'red' : 'green');
    }

    process.exit(errorCount > 0 ? 1 : 0);

  } catch (error) {
    log(`Error: ${error.message}`, 'red');
    process.exit(1);
  }
}

// Run the formatter
main().catch(console.error);