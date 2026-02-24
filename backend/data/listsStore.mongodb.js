const mongoose = require('mongoose');

// ── Schema ──────────────────────────────────────────────────────────────
const listItemSchema = new mongoose.Schema({
  id:       { type: String, required: true },
  name:     { type: String, required: true },
  qty:      { type: Number, default: 1 },
  checked:  { type: Boolean, default: false },
  priority: { type: Number, default: 0 },
}, { _id: false });

const groceryListSchema = new mongoose.Schema({
  id:        { type: String, required: true, unique: true },
  name:      { type: String, required: true },
  items:     { type: String, default: '0/0' },
  progress:  { type: Number, default: 0 },
  priority:  { type: Number, default: 0 },          // 0 = Normal, 1 = Urgent
  time:      { type: String, default: '' },
  icon:      { type: String, default: 'list' },
  listItems: { type: [listItemSchema], default: [] },
}, { timestamps: true });

const GroceryList = mongoose.model('GroceryList', groceryListSchema);

// ── Helpers ─────────────────────────────────────────────────────────────
const safeQty = (qty) =>
  (typeof qty === 'number' && !Number.isNaN(qty) && qty > 0) ? qty : 1;

const recomputeMetadata = (list) => {
  if (!list) return;
  const items = list.listItems || [];
  let totalQty = 0;
  let checkedQty = 0;
  for (const it of items) {
    const q = safeQty(it.qty);
    totalQty += q;
    if (it.checked) checkedQty += q;
  }
  list.items = `${checkedQty}/${totalQty}`;
  list.progress = totalQty > 0 ? +(checkedQty / totalQty).toFixed(2) : 0;
};

// Convert Mongoose doc → plain object (drop _id, __v)
const toPlain = (doc) => {
  if (!doc) return null;
  const obj = doc.toObject();
  delete obj._id;
  delete obj.__v;
  delete obj.createdAt;
  delete obj.updatedAt;
  return obj;
};

// ── CRUD ────────────────────────────────────────────────────────────────
const getAll = async () => {
  const docs = await GroceryList.find().lean();
  return docs.map(({ _id, __v, createdAt, updatedAt, ...rest }) => rest);
};

const getById = async (id) => {
  const doc = await GroceryList.findOne({ id });
  return doc ? toPlain(doc) : null;
};

const create = async (listData) => {
  const newList = {
    ...listData,
    listItems: listData.listItems ? [...listData.listItems] : [],
  };
  recomputeMetadata(newList);
  const doc = await GroceryList.create(newList);
  return toPlain(doc);
};

const update = async (id, listData) => {
  const existing = await GroceryList.findOne({ id });
  if (!existing) return null;

  // Merge fields
  existing.name = listData.name !== undefined ? listData.name : existing.name;
  existing.time = listData.time !== undefined ? listData.time : existing.time;
  existing.icon = listData.icon !== undefined ? listData.icon : existing.icon;
  if (listData.priority !== undefined) existing.priority = listData.priority;

  // Handle listItems
  if (listData.listItems) {
    existing.listItems = listData.listItems.map(it => ({ ...it }));
    existing.markModified('listItems');
  }

  // Recompute items/progress from listItems
  recomputeMetadata(existing);

  await existing.save();
  return toPlain(existing);
};

const remove = async (id) => {
  const result = await GroceryList.deleteOne({ id });
  return result.deletedCount > 0;
};

const reset = async () => {
  await GroceryList.deleteMany({});
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  remove,
  reset,
  GroceryList,
};
