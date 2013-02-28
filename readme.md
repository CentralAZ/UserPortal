# CentralAZ.com UserPortal

This is an Arena Module to allow a user to edit their personal information on your church's public Arena website.

## Installation

To install download the latest zip or tarball and unpack it into the Arena folder on your server. No module definition is necessary. Simply create a new Advanced HTML Module on the page, and include the following code snippet in the "Details" section of the module.

```html
<div id="user-portal-container"></div>
<script type="text/javascript" src="Include/Scripts/Custom/Cccev/lib/underscore.min.js"></script>
<script type="text/javascript" src="Include/Scripts/Custom/Cccev/lib/backbone.min.js"></script>
<script type="text/javascript" src="Include/Scripts/Custom/Cccev/lib/mustache.min.js"></script>
<script type="text/javascript">
    $(function() {
        CentralAZ.UserPortal.Helpers.Bootstrapper.initUserInfo();
    });
</script>
```

In addition to the client side functionality, there are a couple of .dll files you'll need for the web service to work. Download the links below and include them in your Arena/bin folder. 