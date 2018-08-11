ProcessBookletOrderJS= app.trustedFunction(function()
{
var nNumCopies = 1; // make 1 additional copy(es) of each page

var dialogTitle = "Question.";
var pagesPerFold = app.response("How many pages per fold?",
			                          dialogTitle);


var newName = this.path;
var filename = newName.replace(".pdf","_Booklet_Order.pdf");

app.beginPriv();
var newDoc = app.newDoc();
app.endPriv();

var newPagenum = 0;
var totalPages = this.numPages;
i2 = 0;
var x = [];

   while (i2 < totalPages)
   {
   // populate pointer array
   for(i=0; i<pagesPerFold; i++) {
	    				if ((i2 + i) >= totalPages) { break; }
	    				x[i] = i2 + i;
				   }

     while (x.length > 0)
     {
	console.println("array length equals " + x.length);
        insertme = x.pop();
	console.println("array length equals (after) " + x.length);
	console.println("insertme equals " + insertme);
        newDoc.insertPages({ nPage:newPagenum , cPath:this.path, nStart:insertme, nEnd:insertme });
	newPagenum++;

	//round 2
	if (x.length > 0)
        {
           insertme = x.shift();
           newDoc.insertPages({ nPage:newPagenum , cPath:this.path, nStart:insertme, nEnd:insertme });
	   newPagenum++;
        }

	//round 4
	if (x.length > 0)
        {
           insertme = x.shift();
           newDoc.insertPages({ nPage:newPagenum , cPath:this.path, nStart:insertme, nEnd:insertme });
	   newPagenum++;
        }

	//round 4
	if (x.length > 0)
        {
           insertme = x.pop();
           newDoc.insertPages({ nPage:newPagenum , cPath:this.path, nStart:insertme, nEnd:insertme });
	   newPagenum++;
        }


     }
     i2 = i2 + parseInt(pagesPerFold);
   }

   if (newDoc.numPages > 1)
      {
	  newDoc.deletePages(0);  // this gets rid of the page that was created with the newDoc call.
      }

}
)

// add the menu item
app.addMenuItem({
     cName: "BookletOrderJS",     // this is the internal name used for this menu item
     cUser: "Booklet Order",       // this is the label that is used to display the menu item
     cParent: "Document",              // this is the parent menu. The file menu would use "File"
     cExec: "ProcessBookletOrderJS()",  // this is the JavaScript code to execute when this menu item is selected
     cEnable: "event.rc = (event.target != null);",       // when should this menu item be active?
     nPos: 0
});
