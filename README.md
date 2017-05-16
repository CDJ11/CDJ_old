![Logo of Consul](http://www.aude.fr/images/GBI_CG11/logo.png)

# CDJ

Citizen Participation and Open Government Application

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

[![Accessibility conformance](https://img.shields.io/badge/accessibility-WAI:AA-green.svg)](https://www.w3.org/WAI/eval/Overview)

This is the opensource code repository of the eParticipation website for the Conseil Departemental des Jeunes based originally on the Madrid City government eParticipation website

## Current state

Development started on [2017 April 15th]. Code will be deployed to production around 2017 september to [cdj11.aude.fr](https://cdj11.aude.fr). 

## Tech stack

The application backend is written in the [Ruby language](https://www.ruby-lang.org/) using the [Ruby on Rails](http://rubyonrails.org/) framework.

Frontend tools used include [SCSS](http://sass-lang.com/) over [Foundation](http://foundation.zurb.com/) for the styles.

## Configuration for development and test environments

Prerequisites: install git, Ruby 2.3.2, bundler gem, ghostscript and PostgreSQL (>=9.4).

```
git clone https://github.com/CDJ11/consul.git
cd consul
bundle install
bin/rake db:migrate RAILS_ENV=development
Run the app locally:
```
bin/rails s

```
You can use the default admin user from the seeds file:

 **user:** admin@consul.dev
 **pass:** 12345678

But for some actions like voting, you will need a verified user, the seeds file also includes one:

 **user:** verified@consul.dev
 **pass:** 12345678

### Customization

See [CUSTOMIZE_ES.md](CUSTOMIZE_ES.md)

### OAuth

To test authentication services with external OAuth suppliers - right now Twitter, Facebook and Google - you'll need to create an "application" in each of the supported platforms and set the *key* and *secret* provided in your *secrets.yml*

In the case of Google, verify that the APIs *Contacts API* and *Google+ API* are enabled for the application.

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

## Contributions

See [CONTRIBUTING_EN.md](CONTRIBUTING_EN.md)
