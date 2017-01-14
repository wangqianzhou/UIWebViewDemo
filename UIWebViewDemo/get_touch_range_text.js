function(x, y) {

  function getElementText(elmt) {
    var selection = window.getSelection();
    var range = document.createRange();
    range.selectNodeContents(elmt);
    selection.removeAllRanges();
    selection.addRange(range);

    return selection.toString();
  }

  var elmt = document.elementFromPoint(x, y);

  return getElementText(elmt);
}
