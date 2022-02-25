# cjar 0.1.0

* Initial CRAN Submission Version
* added cja_auth() and other JWT authorization enabling functions
* added cja_get_me() which pulled the information for the JWT authorized user
* added cja_get_dataviews() to pull a list of all data views available
* added cja_freeform_table() function to pull data as in workspace
* added cja_get_audit_logs() function to pull audit logs
* added cja_get_metrics(), cja_get_dimensions(), cja_get_calculatedmetrics(), cja_get_filters() and other functions to pull elements data relating to available data in specific data views
* added filter function such as filter_build() to enable the development, validation, and creation of filters in CJA
* added cja_get_projects() to pull all projects available in a specified dataviewId

# cjar 0.0.0.9008

* Added a `NEWS.md` file to track changes to the package.
* Set version number for dev version of the package
* Added initial functions
