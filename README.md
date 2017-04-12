# WARNING: THIS PROJECT ASSUMES PRE-CONFIGURED IMAGES. THIS WILL LIKELY NOT WORK OUTSIDE INTERNAL CHEF

## Purpose
Creating machines for students to use in our [onsite Chef training](https://training.chef.io/training/onsite.html) takes manual effort. I don't like manual effort. This project reduces manual effort significantly.

This project does the following:
  - Creates machines for [onsite Chef training](https://training.chef.io/training/onsite.html)
  - Creates a Markdown file that assigns machines to students

## How To Use

1. Verify `~/.aws/credentials` is configured. (see [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html))
2. Change directories into `exe/`
3. Copy `config.yml.example` to `config.yml`
2. Modify `config.yml`
    - Modify class type
    - Modify company name
    - Modify tag info (X-Dept, X-Contact)
    - Modify student list
3. Run `./garcon`
4. Create a GitHub Gist from resulting Markdown in `output/` (I recommend using <https://github.com/defunkt/gist>)
5. Profit

## Cleanup

### Automatic
1. Run `./garcon -destroy -force`

### Manual
2. Run `terraform destroy -force` in the terraform directory corresponding to your class (Example: `output/2017-04-06-Testing-chef-essentials-windows/terraform/`)

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

## Testing

This project has `rspec` tests. To run them run `rspec` in the root of this project.
