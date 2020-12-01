[![img](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Grizzly Bear Status Indicator

This repository contains R code that summarizes the status of grizzly bears in British Columbia. It supports the '[Grizzly Bear Conservation Ranking in B.C.](http://www.env.gov.bc.ca/soe/indicators/plants-and-animals/grizzly-bears.html)' indicator published on [Environmental Reporting BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B) Nov, 2020.

### Data

This indicator uses data sourced from the [B.C. Data Catalogue](https://catalogue.data.gov.bc.ca/dataset) distributed under the [Open Government Licence - British Columbia](https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61).

- [Grizzly Bear Population Units](https://catalogue.data.gov.bc.ca/dataset/caa22f7a-87df-4f31-89e0-d5295ec5c725)
- [BC Grizzly Bear Conservation Ranking Results](https://catalogue.data.gov.bc.ca/dataset/e08876a1-3f9c-46bf-b69a-3d88de1da725)
- [BC Grizzly Bear Population Estimates](https://catalogue.data.gov.bc.ca/dataset/2bf91935-9158-4f77-9c2c-4310480e6c29)
- [Grizzly Bear Historic Mortality](https://catalogue.data.gov.bc.ca/dataset/history-of-grizzly-bear-mortalities/resource/c5fc42c7-67d3-4669-b281-61dc50fdef22)

### Usage

There are four core scripts that are required for the analysis, they
need to be run in order:

-   01\_load.R
-   02\_clean.R
-   03\_visualizion.R
-   04\_outputs.R

Most packages used in the analysis can be installed from CRAN using `install.packages()`, but you will need to install [`envreportutils`](https://github.com/bcgov/envreportutils) and [`bcdata`](https://github.com/bcgov/bcdata) using remotes:

```r
install.packages("remotes") # if you don't already have it installed

library(remotes)
install_github("bcgov/envreportutils")
install_github("bcgov/bcdata")
```

### Project Status
This project is under active development.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/grizzly-bear-status-indicator/issues/).

### How to Contribute

If you would like to contribute, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

### License

    Copyright 2019 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

------------------------------------------------------------------------
This repository is maintained by [Environmental Reporting BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B). Click [here](https://github.com/bcgov/EnvReportBC) for a complete list of our repositories on GitHub.

*This project was created using the
[bcgovr](https://github.com/bcgov/bcgovr) package.*
