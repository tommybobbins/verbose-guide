# cuddly-guide
chegwin.org website

## INSTALL

## Install the infrastructure for Deploying to AWS

``` 
cd infrastructure
tofu init
tofu plan
tofu apply
```

## Deploy the hugo locally

Clone this repository

``` 
   $ git clone https://github.com/tommybobbins/cuddly-guide
```
 
Change into the cuddly-guide directory and then initialise the submodules.

```
   $ git submodule init

   Submodule 'hugo/themes/hugo-hero-theme' (https://github.com/zerostaticthemes/hugo-hero-theme) registered for path 'themes/hugo-hero-theme'

   $ git submodule update

```

## Create an invalidation in CloudFront

```
aws cloudfront create-invalidation --distribution-id E3HZXPE32BOCAS --paths "/*";
```
