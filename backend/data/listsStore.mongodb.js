const mongoose = require('mongoose');

// ── Schema ──────────────────────────────────────────────────────────────
const listItemSchema = new mongoose.Schema({
  id:       { type: String, required: true },
  name:     { type: String, required: true },
  name_ar:  { type: String, default: '' },
  qty:      { type: Number, default: 1 },
  checked:  { type: Boolean, default: false },
  priority: { type: Number, default: 0 },
  emoji:    { type: String, default: '' },
}, { _id: false });

const groceryListSchema = new mongoose.Schema({
  id:         { type: String, required: true, unique: true },
  name:       { type: String, required: true },
  items:      { type: String, default: '0/0' },
  progress:   { type: Number, default: 0 },
  priority:   { type: Number, default: 0 },          // 0 = Normal, 1 = Urgent
  time:       { type: String, default: '' },
  category:   { type: String, default: null },
  icon:       { type: String, default: 'list' },
  listItems:  { type: [listItemSchema], default: [] },
  ownerId:    { type: String, default: null },        // userId of list creator
  guestId:    { type: String, default: null },        // guest session/device id
  sharedWith: { type: [String], default: [] },        // userIds who accepted invite
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
  // Also strip _id from each listItem subdocument
  if (Array.isArray(obj.listItems)) {
    obj.listItems = obj.listItems.map(({ _id, ...rest }) => rest);
  }
  return obj;
};

// ── CRUD ────────────────────────────────────────────────────────────────
const getAll = async () => {
  const docs = await GroceryList.find().lean();
  return docs.map(({ _id, __v, createdAt, updatedAt, ...rest }) => rest);
};

/**
 * Return lists visible to a user:
 *   - Authenticated: lists they own OR are shared with them.
 *   - Guest (no userId): ONLY lists with their guestId (private per device/session).
 */
const getAllForUser = async (userId, guestId = null) => {
  if (!userId) {
    // Guest session — only show lists for this guestId
    if (!guestId) return [];
    const docs = await GroceryList.find({ ownerId: null, guestId }).lean();
    return docs.map(({ _id, __v, createdAt, updatedAt, ...rest }) => rest);
  }
  const docs = await GroceryList.find({
    $or: [{ ownerId: userId }, { sharedWith: userId }],
  }).lean();
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
  existing.category = listData.category !== undefined ? listData.category : existing.category;
  existing.icon = listData.icon !== undefined ? listData.icon : existing.icon;
  if (listData.priority !== undefined) existing.priority = listData.priority;

  // Always update listItems and mark as modified, even if empty or mutated in-place
  if (listData.listItems !== undefined) {
    existing.listItems = Array.isArray(listData.listItems)
      ? listData.listItems.map(it => ({ ...it }))
      : [];
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

/**
 * Add a userId to the sharedWith array of a list (idempotent).
 */
const addSharedUser = async (listId, userId) => {
  await GroceryList.updateOne(
    { id: listId },
    { $addToSet: { sharedWith: userId } }
  );
};

module.exports = {
  getAll,
  getAllForUser,
  getById,
  create,
  update,
  remove,
  reset,
  addSharedUser,
  /**
   * Migrate all lists for a guestId to a userId (on login)
   */
  async migrateGuestListsToUser(guestId, userId) {
    if (!guestId || !userId) return 0;
    const result = await GroceryList.updateMany(
      { guestId },
      { $set: { ownerId: userId }, $unset: { guestId: "" } }
    );
    return result.modifiedCount || 0;
  },
  GroceryList,
};
