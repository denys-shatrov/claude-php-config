<?php

// Automated modernisation of code for the current PHP and Laravel versions.
// Install: composer require --dev rector/rector driftingly/rector-laravel
// Preview: vendor/bin/rector --dry-run     <- always start here
// Apply:   vendor/bin/rector
//
// How to use it: run one rule set at a time, one commit per run, tests in
// between. Rector rewrites many files at once, and mixing its edits with
// hand-written ones makes the diff unreviewable.

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\Set\ValueObject\LevelSetList;
use Rector\Set\ValueObject\SetList;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/app',
        __DIR__ . '/database',
        __DIR__ . '/routes',
        __DIR__ . '/tests',
    ])
    ->withSkip([
        __DIR__ . '/bootstrap/cache',
        __DIR__ . '/storage',
        __DIR__ . '/vendor',
    ])
    // Raise this to the version actually declared in composer.json.
    ->withSets([
        LevelSetList::UP_TO_PHP_83,
        SetList::CODE_QUALITY,
        SetList::DEAD_CODE,
        SetList::TYPE_DECLARATION,
    ])
    ->withImportNames(removeUnusedImports: true);
