require 'webfinger';
require 'person';
require 'pp'
x = Webfinger.new("h4ck3rm1k@joindiaspora.com").fetch
pp x
