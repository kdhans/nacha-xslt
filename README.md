# nacha-xslt
Takes an XML report of payments in a webservice enabled accounting system, and transforms it to a NACHA ready file (IAT, CCD &amp; PPD). Assumes USD to USD.

Couple of things to do if you take these examples:
+ These files assume one batch (5 record) but transformation should be relatively easy if you need to do multiple batches. Would reccomend iterating your XML based on payment date.
+ IAT assumes USD to USD, and a USD holding account for the recipient. This can be remedied with a more robust XML file coming in, and using the data values on the XML instead of the variables.
+ All variables should be reviewed and matched to your company's usage 
