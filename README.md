# Ruby on Rails Stripe Sample starter

[🎬 Watch on YouTube](https://youtu.be/8aA9Enb8NVc)

Note: This demo does *not* implement any Stripe logic, and is a foundation for
other demos.

In this demo we cover foundational topics and dig into the basics of Ruby on
Rails the web framework, how it works and how we use Rails as a base for
developer office hours episodes and also in the Stripe samples - a collection
of github repositories demonstrating integrations with many Stripe products.

You may be just getting started and are curious about how to build an
application from scratch to take your first online payment. This episode will
cover some basics to help you get started quickly with ruby and rails. If you
already have a backend setup, are comfortable adding new routes, and are now
looking to add a Stripe integration, you may want to check out other office
hours episodes where we show how to integrate specific Stripe products and
features. Similarly, if you’re looking for an introduction to a more minimal
web framework in Ruby, I’d recommend taking a look at Sinatra. We have another
episode for getting started with Sinatra.

### Why [Rails](https://rubyonrails.org/)?

Rails is an opinionated, feature rich and popular web framework. It includes
everything needed to create database-backed web applications.

Demos written with rails, allow us to leverage rails conventions and built in
[ORM](https://guides.rubyonrails.org/active_record_basics.html) to build data
backed demos, demonstrate
[CSRF](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf),
authentication, [background
jobs](https://guides.rubyonrails.org/active_job_basics.html),
[email](https://guides.rubyonrails.org/action_mailer_basics.html) and more.
Features that are more challenging to show with minimal frameworks because
while they are possible with third party libraries, the solutions are
more tailor fit.

If you’re working in a more minimal web framework like [Sinatra](http://sinatrarb.com/), the same
fundamentals we cover in this episode apply, but are implemented a little
differently across a bigger more opinionated codebase.

Today, we’ll cover setting up a basic front-end with the standard built in
`html.erb`. In another, future, episode we’ll go into more detail for how we
setup front end frameworks like React to work with Rails.

It may be helpful to watch the introduction to the [Stripe
CLI](https://www.youtube.com/watch?v=Psq5N5C-FGo).

In this demo, you'll learn how to

- Configure your Stripe API keys and create an [initializer](./config/initializers/stripe.rb)
- How to setup client with a basic static html.erb views and Stripe.js installed
- Install dependencies with bundler and a [Gemfile](./Gemfile)
- Implement basic routes and controllers to support GET and POST and pass data between the front end and back end
- How to setup a basic Webhooks Controller


From the terminal, use the `rails new` command to create a brand new rails
application. My preferred database is `postgresql`, but rails has support for
several other [flavors of DB](https://guides.rubyonrails.org/v2.3/getting_started.html#configuring-a-database).

```sh
rails new office-hours-rails -T --database=postgresql --skip-turbolinks --skip-listen
```

-T skips tests, by default rails uses minitest while I prefer rspec
--database=postgresql tells rails to configure our database to use postgres
--skip-turbolinks prevents the installation of turbolinks
--skip-listen prevents the configuration that depends on the listen gem which has some issues in some unix environments

This will take a moment to install the dependencies, create all of the files we
want install some front end assets.

Now you can change directories into the new office-hours-rails directory and
take a look at what we were given.

```sh
cd office-hours-rails
ls
```

Next, let’s use the credential management to set our API keys. We set an
environment variable here for EDITOR, this could be your editor of choice like
vs code, atom, sublime, emacs or whatever:


`rails credentials:edit` will decrypt the credentials file using the
`config/master.key` file in config, then allow you to edit the yaml, and when
you exit the file will be re-encrypted.

```sh
EDITOR=vi rails credentials:edit
```

This is how we setup API keys for the demo, your setup may vary and could
support multiple environments for instance production vs development or
similar. For demos, we always just use test API keys and can use this top level
yaml block like so:

```yml
stripe:
  secret_key: sk_test_...
  public_key: pk_test_...
  webhook_secret: whsec_...
```

Close and save.

Next we want to install some dependencies. We can do so by opening the
[Gemfile](./Gemfile) in the root of the project:

Uncomment `bcrypt`
Add `pry-rails` and `annotate` to the development section
Add `stripe`


We can install those with `bundle install`

When you run a rails application, it’ll first load the framework and any gems
for the application, then load these files called initializers. They live in
`config/initializers`

You can use initializers to hold configuration settings that should be made
after all of the frameworks and gems are loaded, such as setting your Stripe
API key.

Create a new file called `stripe.rb` in `config/initializers` where we can
globally set our API key which will be retrieved from the credential file we
set in the last step.

```rb
Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
```

At this point, we can make API calls to the Stripe API. Running `rails console`
or `rails c` for short, in the terminal will give us an interactive shell where
we can experiment with requests.

`rails c`

```rb
Stripe::Price.list
```

Looks like our API key was set correctly and we’re able to fetch a list of
Prices! Nice!

The final dependency we’ll install is [Stripe.js](https://stripe.com/docs/js),
In Rails applications, there is a file called
[`application.html.erb`](./app/views/layouts/application.html.erb) where the
master html layout file lives.  It is generally the file which wraps all other
views and is where we want to install Stripe.js.

Technically, we can install Stripe.js anywhere as long as it’s loaded before we
try to use it. To ensure it’s ready to go, I like to put it in the head above
the other javascript include tags.

Excellent! We now have a rough outline of an application with dependencies
installed and Stripe ruby configured for us to begin making API calls.

### Controllers and Routes

Next, we’ll create a controller and some associated views to see how to handle
requests.

```sh
rails generate controller Orders --no-helper --no-assets
```

That will generate a new file with a class responsible for receiving and
responding to requests. Rails applications generally follow very strong
conventions to help developers build applications faster.

Controllers typically have one or many standard actions, but can also have
custom routes.

The standard actions are:

- Index
- Show
- New
- Create
- Edit
- Update
- Destroy

Index is for retrieving a list of items, show is for a single item, new is for
rendering the form to create something, create is the action that receives POST
requests and actually creates the item, edit is for retrieving the form and
update is for receiving the PUT request to update the given item and destroy is
for deleting the item.

When adding actions to a controller, to route requests to the right controller
action, we must update our [`routes.rb`](./config/routes.rb) file, a
configuration where the list of path and controller action mapping is setup.

There is an entire routes
[DSL](https://en.wikipedia.org/wiki/Domain-specific_language) or domain
specific language for [defining
routes](https://guides.rubyonrails.org/routing.html).  We’ll generally use the
`resources` method and pass it the conventional name which matches the
controller we created. This will match the seven standard paths which map to
the seven standard controller actions. For custom routes, we’ll use get or
post.

Now let’s try using our new orders controller to handle some requests and generate responses.

```rb
def index
  orders = [1, 2, 3, 99]
  eender json: orders
end
```

```sh
curl localhost:3000/orders
```

These routes can also render html and work with erb template files. Let’s
update our index to render a view.

Next we'll create a Static pages controller that simply handles requests to the root route ('/')

```sh
rails g controller StaticPages root --no-helper --no-assets
```

### Webhooks

The key points for working with webhooks in Rails, is that because the POST
request is coming from Stripe rather than a form on a page that you host, CSRF
will need to be disabled on this controller.

You can disable CSRF at the top of a controller by adding:

```rb
skip_before_action :verify_authenticity_token
```

To learn more about webhooks, see the [official documentation](https://stripe.com/docs/webhooks/build) or [🎬 watch the Webhooks ep.](https://youtu.be/oYSLhriIZaA).
