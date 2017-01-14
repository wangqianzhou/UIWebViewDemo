(function() {
    var ret = window.getSelection().toString();
    if (ret && ret.length > 0)
    {
        return ret;
    }
    
    var selectionText;
    var allFrames = document.querySelectorAll('iframe');
    for (var i = 0; i < allFrames.length; ++i)
    {
        try
        {
            var frameWindow = allFrames[i].contentWindow;
            var temp = frameWindow.getSelection().toString();
            if (temp.length > 0)
            {
                ret = temp;
                break;
            }
        }
        catch (e)
        {
            continue;
        }
    }
    
    return ret;
})();