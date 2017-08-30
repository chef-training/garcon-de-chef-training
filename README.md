# WARNING: THIS PROJECT ASSUMES PRE-CONFIGURED IMAGES. THIS WILL LIKELY NOT WORK OUTSIDE INTERNAL CHEF
# DOUBLE WARNING: THE ABOVE IS ESPECIALLY TRUE FOR CHEF ESSENTIALS WINDOWS IT WILL ONLY WORK IN THE TRAINING AWS ACCOUNT

## Purpose
Creating machines for students to use in our [onsite Chef training](https://training.chef.io/training/onsite.html) takes manual effort. I don't like manual effort. This project reduces manual effort significantly.

This project does the following:
  - Creates machines for [onsite Chef training](https://training.chef.io/training/onsite.html)
  - Creates a Markdown file that assigns machines to students

## Prerequisites

### Terraform
This project depends on Hashicorp Terraform to create resources in AWS. Ensure Terraform is installed by installing from [here](https://www.terraform.io/downloads.html).

> NOTE: This guide assumes that the Terraform binary is in your PATH environment variable. Your package manager should handle this. If not, place the binary in `/usr/local/bin` or if on Windows, create a directory containing that binary and add it to your `%PATH%` (Example: `C:\Hashicorp\terraform`)


### AWS CLI
Terraform uses the AWS CLI  to perform the actions of the AWS provider. To install the AWS CLI follow the guide [here](http://docs.aws.amazon.com/cli/latest/userguide/installing.html).

Make sure to configure your `~/.aws/credentials` as well (see [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)).

## How To Use

1. Verify `~/.aws/credentials` is configured. (see [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html))
2. Copy `config.yml.example` to `config.yml`
3. Modify `config.yml`
    - Modify class type
    - Modify company name
    - Modify tag info (X-Dept, X-Contact)
    - Modify student list
4. Run `rake create` or `./exe/garcon PATH_TO_CONFIG_YAML create`
5. Verify that the AMIs used match the AMIs in Appendix Z of your training material
6. Create a GitHub Gist from resulting Markdown in `output/` (I recommend using <https://github.com/defunkt/gist>)
7. Profit

## Cleanup

### Automatic
1. Run `rake destroy:force` or `./exe/garcon PATH_TO_CONFIG_YAML destroy --force`

### Manual
2. Run `terraform destroy` in the terraform directory corresponding to your class (Example: `output/2017-04-06-Testing-chef-essentials-windows/terraform/`)

## Using Multiple AWS Accounts

Since this project uses Terraform you have the option to configure it to use an multiple AWS accounts. To do this you need to configure profiles in your `~/.aws/config`. A detailed guide on this process can be found [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles).

TL;DR:
  1. Add a profile block to your `~/.aws/config`. Example:
  ```
  [default]
  region=us-west-2
  output=json

  [profile other-account]
  region=us-east-1
  output=json
  ```
  2. Add credentials for your profile to `~/.aws/credentials`. Example:
  ```
  [default]
  aws_access_key_id=AKIAIOSFODNN7EXAMPLE
  aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

  [other-account]
  aws_access_key_id=AKIAI44QH8DHBEXAMPLE
  aws_secret_access_key=je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
  ```
  3. Modify profile value in your `config.yml`
  4. Follow other parts of the `How to Use` section above

> NOTE: Should you have AWS access and secret keys hardcoded as environment variables Terraform will give these values precedence. You may wish to update those entries or manage your AWS credentials as indicated above.

## Testing

This project both conforms to RuboCop standards and has RSpec tests.

To run both use: `rake test`

To run just RSpec run: `rake test:unit`

To run just RuboCop run: `rake test:lint`
