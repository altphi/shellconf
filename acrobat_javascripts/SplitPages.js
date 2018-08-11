ProcessDocument = app.trustedFunction(function()
{
    // new document
    app.beginPriv();
    var newDoc = app.newDoc();
    app.endPriv();

    var i = 0;
    while (i < this.numPages)
    {
        newDoc.insertPages( {
            nPage: newDoc.numPages-1,
            cPath: this.path,
            nStart: i
        });
        newDoc.insertPages( {
            nPage: newDoc.numPages-1,
            cPath: this.path,
            nStart: i
        });
        i++;
    }

    if (newDoc.numPages > 1)
    {
        newDoc.deletePages(0);
    }

    for (i=0; i<newDoc.numPages; i++)
    {
        var cropRect = newDoc.getPageBox("Crop", i);
        var halfWidth = (cropRect[2]-cropRect[0])/2;

        var cropLeft = new Array();
        cropLeft[0] = cropRect[0];
        cropLeft[1] = cropRect[1];
        cropLeft[2] = cropRect[0] + halfWidth;
        cropLeft[3] = cropRect[3];

        var cropRight = new Array();
        cropRight[0] = cropRect[2] - halfWidth;
        cropRight[1] = cropRect[1];
        cropRight[2] = cropRect[2];
        cropRight[3] = cropRect[3];

        if (i%2 == 0)
        {
	   newDoc.setPageBoxes( {
	       cBox: "Crop",
	       nStart: i,
	       rBox: cropLeft
	       });
        }
        else
        {
	   newDoc.setPageBoxes( {
	       cBox: "Crop",
	       nStart: i,
	       rBox: cropRight
	       });
        }
    }
}
)

app.addMenuItem({
     cName: "splitPagesJS",
     cUser: "Split Pages",
     cParent: "Edit",
     cExec: "ProcessDocument()",
     cEnable: "event.rc = (event.target != null);",
     nPos: 0
});
