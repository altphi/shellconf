RealCrop = app.trustedFunction(function()
{
    // go to first page
    this.pageNum = 0;
    var i = 0;
    var aRect;

    while (i < this.numPages)
    {
      aRect = this.getPageBox("Crop", this.pageNum);
      this.setPageBoxes({
        	cBox: "Media",
        	nStart: this.pageNum,
        	nEnd: this.pageNum,
        	rBox: [aRect[0],aRect[1],aRect[2],aRect[3]]
	});
      i++;
      this.pageNum++;
    };
}
)

app.addMenuItem({
     cName: "RealCropJS",
     cUser: "Real Crop",
     cParent: "Edit",
     cExec: "RealCrop()",
     cEnable: "event.rc = (event.target != null);",
     nPos: 0
});
