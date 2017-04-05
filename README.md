# WARNING: THIS PROJECT ASSUMES PRE-CONFIGURED IMAGES. THIS WILL LIKELY NOT WORK OUTSIDE INTERNAL CHEF

## Purpose
Creating machines for students to use in our [onsite Chef training](https://training.chef.io/training/onsite.html) takes manual effort. I don't like manual effort. This project reduces manual effort significantly.

This project does the following:
  - Creates machines for [onsite Chef training](https://training.chef.io/training/onsite.html)
  - Creates a Markdown file that assigns machines to students

## How To Use

1. Verify `~/.aws/credentials` is configured. (see [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html))
2. Modify `variables.yml`
  - Modify class type
  - Modify company name
  - Modify tag info (X-Dept, X-Contact)
  - Modify student list
3. Run `ruby create_classroom.rb`
4. Create a GitHub Gist from resulting Markdown in `output/` (I recommend using <https://github.com/defunkt/gist>)
5. Profit

## Cleanup

1. Run `terraform destroy` in the terraform directory corresponding to your class (`output/class_identifier/terraform`)
