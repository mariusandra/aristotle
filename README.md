# Aristotle

Aristotle is a simple business logic engine for Ruby. It's design goal is to stop clients from asking
"How does this work?" and "Why does this happen?".

Aristotle achieves this by removing the line between business logic definitions and code. The same
lines of text that are used to define logic rules can be displayed to the client without modification.

Aristotle is loosely inspired by cucumber. Check out the examples below.

We're at an early alpha version, so all contributions are very welcome! Most appreciated are unit tests and code cleanups.

Aristotle grew out of the need we had at [Apprentus](https://www.apprentus.com/) to define and remember the ever increasing
complexity with sorting and managing incoming requests from students.

## Installation

Put this in your Gemfile

    gem 'aristotle'

## Usage

Create a folder `app/logic` and place inside files like:

`app/logic/request.logic`

```ruby
Update the request state

  Do nothing if the state was manually changed
  Move to 'to_do' if the last message changed and is unverified
  Move to 'failed' if the last message is sent and it is 'booking declined' or 'booking expired'
  Move to 'deleted' if there are no messages in this request
```

`app/logic/request_logic.rb`

```ruby
class RequestLogic < Aristotle::Logic
  # conditions
  condition /the state was manually changed/ do |request|
    request.state_changed?
  end

  condition /the last message changed and is unverified/ do |request|
    request.last_message_id_changed? && request.state != :to_do && !request.last_message.try(:sent?)
  end

  condition /the last message is sent and it is 'booking declined' or 'booking expired'/ do |request|
    last_message = request.messages.latest_first.first
    last_message.present? && last_message.sent? && last_message.action.in?(:decline, :expire)
  end

  condition /there are no messages in this request/ do |request|
    request.messages.count == 0
  end

  # actions
  action /Do nothing/ do |request|
  end

  action /Move to '([a-z_]+)'/ do |request, folder|
    request.state = folder.to_sym
  end
end
```

To check that all the rules are defined, run `aristotle` from the command line. You'll get either:

```
$ aristotle
Checking RequestLogic
-> Everything is covered!
```

or

```
$ aristotle
Checking RequestLogic

class RequestLogic < Aristotle::Logic
  # Update the request state:
  condition /it's a non-HOT request with all the messages sent/ do |request|

  end

end
```

To use the logic in your own models and controllers, do this:

```ruby
class Request < ActiveRecord::Base
  before_save :update_state

  def update_state
    RequestLogic.new(self).process 'Update the request state'
  end
end
```

### Displaying rules

To display a nice HTML version of the rules (e.g. in your admin interface for the client), run:

```ruby
RequestLogic.html_rules(show_code: true)
```

Here's an example. The box around is made by [activeadmin](http://activeadmin.info/).

![Aristotle rules example](http://mariusandra.com/files/aristotle/aristotle-rules.png)

## Contributions

All contributions are very welcome! This is an alpha release of the code.
