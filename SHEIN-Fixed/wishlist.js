/* ==========================================================================
   SHESTYLE — wishlist.js
   Shared wishlist storage helpers (localStorage), used on every page.
   ========================================================================== */
const WISHLIST_KEY = "shestyle_wishlist";

function getWishlist() {
  try {
    return JSON.parse(localStorage.getItem(WISHLIST_KEY) || "[]");
  } catch (e) {
    return [];
  }
}

function isInWishlist(id) {
  return getWishlist().indexOf(id) !== -1;
}

/* Adds/removes the id, returns true if it is now IN the wishlist */
function toggleWishlist(id) {
  var list = getWishlist();
  var idx = list.indexOf(id);
  if (idx === -1) {
    list.push(id);
  } else {
    list.splice(idx, 1);
  }
  localStorage.setItem(WISHLIST_KEY, JSON.stringify(list));
  return idx === -1;
}

function removeFromWishlist(id) {
  var list = getWishlist().filter(function (item) { return item !== id; });
  localStorage.setItem(WISHLIST_KEY, JSON.stringify(list));
}