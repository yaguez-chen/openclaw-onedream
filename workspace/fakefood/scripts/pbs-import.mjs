#!/usr/bin/env node
/**
 * pbs-import.mjs — Import PBS pb-ids.json into fakefood game format
 * 
 * Usage: node scripts/pbs-import.mjs [options]
 *   --ids <path>      Path to pb-ids.json (default: ./pbs/pb-ids.json)
 *   --out <path>      Output path for processed data (default: ./assets/pbs-foods.json)
 *   --filter-food     Only include items with food types (dough, topping, etc.)
 *   --all             Include all items regardless of type
 *   --dry-run         Preview without writing
 */

import { readFileSync, writeFileSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');

// Parse args
const args = process.argv.slice(2);
function getArg(name, fallback) {
  const idx = args.indexOf(`--${name}`);
  if (idx === -1) return fallback;
  return args[idx + 1] || fallback;
}
const hasFlag = (name) => args.includes(`--${name}`);

const IDS_PATH = getArg('ids', join(ROOT, 'pbs/pb-ids.json'));
const OUT_PATH = getArg('out', join(ROOT, 'assets/pbs-foods.json'));
const FILTER_FOOD = hasFlag('filter-food');
const ALL = hasFlag('all');
const DRY_RUN = hasFlag('dry-run');

// PBS categories that map to "food" in fakefood
const FOOD_CATEGORIES = new Set([
  'dough', 'baked', 'frozen', 'sugar', 'meal',
  'garnish', 'mixed', 'topping', 'food', 'chocolate',
  'flavor', 'decoration', 'frosting', 'crust'
]);

// Category → type mapping (for the game's type system)
const CATEGORY_TO_TYPE = {
  dough: 'dough',
  baked: 'baked',
  frozen: 'frozen',
  sugar: 'sugar',
  meal: 'meal',
  garnish: 'garnish',
  mixed: 'mixed',
  topping: 'topping',
  food: 'food',
  chocolate: 'food',
  flavor: 'flavor',
  decoration: 'decoration',
  frosting: 'frosting',
  crust: 'crust',
  dye: 'special',
  dust: 'special',
  dyeIngredient: 'special',
  other: 'special',
  display: 'special',
  platform: 'special',
  hair: 'special',
  'held-item': 'special',
  head: 'special',
  body: 'special',
  legs: 'special',
  feet: 'special',
  gloves: 'special',
  badge: 'special',
  pa-badge: 'special',
  mob: 'special',
};

function transformItem(pbsItem) {
  const cat = pbsItem.category || 'other';
  return {
    id: `pbs-${pbsItem.id}`,
    name: pbsItem.name,
    desc: pbsItem.description || `A ${cat} item.`,
    type: CATEGORY_TO_TYPE[cat] || 'special',
    pbsId: pbsItem.id,
    pbsCategory: cat,
    pbsInternalName: pbsItem.internalName,
    by: 'pbs',
  };
}

// Load
console.log(`📂 Loading: ${IDS_PATH}`);
const raw = JSON.parse(readFileSync(IDS_PATH, 'utf-8'));
console.log(`   Found ${raw.length} PBS items`);

// Filter
let items = raw;
if (FILTER_FOOD) {
  items = raw.filter(i => FOOD_CATEGORIES.has(i.category));
  console.log(`   Filtered to ${items.length} food-type items`);
} else if (!ALL) {
  // Default: include everything but mark types
  console.log(`   Including all ${items.length} items (use --filter-food for food-only)`);
}

// Transform
const transformed = items.map(transformItem);

// Stats
const byType = {};
transformed.forEach(i => { byType[i.type] = (byType[i.type] || 0) + 1; });
console.log(`\n📊 Breakdown by type:`);
Object.entries(byType).sort((a, b) => b[1] - a[1]).forEach(([type, count]) => {
  console.log(`   ${type}: ${count}`);
});

if (DRY_RUN) {
  console.log(`\n🔍 Dry run — showing first 3 items:`);
  transformed.slice(0, 3).forEach(i => console.log(JSON.stringify(i, null, 2)));
  console.log(`\n(Dry run — nothing written)`);
  process.exit(0);
}

// Write
mkdirSync(dirname(OUT_PATH), { recursive: true });
writeFileSync(OUT_PATH, JSON.stringify(transformed, null, 0), 'utf-8');
console.log(`\n✅ Written ${transformed.length} items → ${OUT_PATH}`);
console.log(`   Size: ${(readFileSync(OUT_PATH).length / 1024).toFixed(1)} KB`);
