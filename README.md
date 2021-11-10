
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cjar

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

<!-- <img src="man/figures/logo.png" align="right" width = "200"/> -->

## An R Client for CJA API

Connect to the CJA API, which powers CJA Workspace. The package was
developed with the analyst in mind and will continue to be developed
with the guiding principles of iterative, repeatable, timely analysis.
New features are actively being developed and we value your feedback and
contribution to the process. Please submit bugs, questions, and
enhancement requests as [issues in this Github
repository](https://github.com/searchdiscovery/cjar/issues).

<!-- ### Install the package (recommended) -->
<!-- ``` -->
<!-- # Install from CRAN -->
<!-- install.packages('adobeanalyticsr') -->
<!-- # Load the package -->
<!-- library(adobeanalyticsr)  -->
<!-- ``` -->

### Install the development version of the package

    # Install devtools from CRAN
    install.packages("devtools")

    # Install adobeanayticsr from github
    devtools::install_github('searchdiscovery/cjar') 

    # Load the package
    library(cjar) 

### Current setup process overview

There are four setup steps required to start accessing your Customer
Journey Analytics data. The following steps are each outlined in greater
detail in the following sections:

1.  Create an Adobe Console API Project
2.  Create and add the JWT arguments to your `.Renviron` file.
3.  Get your authorization token by using the function `cja_auth()`.
4.  Get the `Data View ID` by using the function `cja_get_dataviews()`.

#### 1. Create an Adobe Console API Project

Regardless of how many different CJA accounts you will be accessing, you
only need an Adobe Console API project for each. The following

1.  Navigate to the following URL:
    <https://console.adobe.io/integrations>.
2.  Click the **Create New Project** button.
3.  Click the **Add API** button.
4.  Select the Adobe Experience Platform product icon and then choose
    **Adobe Experience Platform** and click **Next**. (need to fill in
    the rest of this process…)
5.  Select the Experience Cloud product icon and then choose **Customer
    Journey Analytics** and click **Next**.
6.  Select **Option 1** and then click **Generate keypair**
7.  A config.zip file will automatically download on your system. Note
    what directory this was downloaded into, we will need this file
    alter.
8.  Click the **Next** button.
9.  Select the Product Profiles you want to access to. Click **Save
    configured API**.
10. Copy and paste the Client ID, Client Secret (click “Retrieve client
    secret”), Technical Account ID, and Organization ID and paste them
    into a .Renviron file in the project or user directory.  
11. Locate the config.zip file that automatically downloaded in step 6.
    Unzip the file and move the ‘private.zip’ file into your working
    directory. The location of this file will be needed as the value of
    the **CJA\_PRIVATE\_KEY** variable.

#### 2. Set up the .Renviron file

This file is essential to keeping your information secure. It also
speeds up analysis by limiting the number of arguments you need to add
to every function call.

1.  If you do not have an `.Renviron` file (if you have never heard of
    this file you almost certainly don’t have one!), then create a new
    file and save it with the name `.Renviron`. You can do this from
    within the RStudio environment and save the file either in your
    `Home` directory (which is recommended; click on the **Home** button
    in the file navigator in RStudio and save it to that location) *or*
    within your project’s working directory.

2.  Get the following variables from the CJA project and config.zip file
    and then add them to the file (see *Creating an Adobe Console API
    Project* above) The format of variables in the `.Renviron` file is
    straightforward.

<!-- -->

    ## JWT creds ##
    CJA_CLIENT_ID=XXXXXXXXXXXXXXXXXXXX
    CJA_CLIENT_SECRET=XXX-XXXXXXXXXXXXXXXXXXXXXXX
    CJA_TECHNICAL_ID=XXXXXXXXXXXXXXXXXXXX@techacct.adobe.com
    CJA_ORGANIZATION_ID=XXXXXXXXXXXXX@AdobeOrg

    CJA_PRIVATE_KEY=private.key

After adding all 5 variables to the `.Renviron` file and saving it,
restart your R session (**Session &gt; Restart R** in RStudio) and
reload `cjar` (`library(cjar)`).

#### 3. Get your access token

The token is actually a lonnnnng alphanumeric string that is the what
ultimately enables you to access your data:

1.  In the console, enter `aw_auth()` and press *Enter*.
2.  In the Console window you should see “Successfully authenticated
    with JWT: access token valid until ….”
3.  If you do not see this message then go back and repeat the previous
    steps to make sure you did not miss something.

#### 4. Get the Data View ID

All data in CJA is located in Data Views, similar to Report Suites in
Adobe Analytics. Before pulling data it is advisable to locate the data
view id of the data you are attempting to pull from.

    #Pull a list of available data views

    dv <- cja_get_dataviews(expansion = c('name', 'description')) 

    #note: see function documentation for all availabe expansion metadata is available.

Once you have the data view ID you want then you can begin pulling data
using all the different functions.
