# discourse_vim

This is a simple command line tool for composing Discourse topics and posts
using vim.

To start copy `config-example.yml` to `config.yml` and edit to your liking.

Then you can start composing posts by following these examples:

``` text
SITE="localhost-user" ruby app.rb new-topic "My title from the command line"
SITE="localhost-user" ruby app.rb new-post 28
SITE="localhost-user" ruby app.rb edit-last-post 28
```

