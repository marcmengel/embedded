require 'redmine'
require 'embedded'

if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    #match 'embedded/:id', :to => 'embedded#index' , :as => 'embedded'
    match 'embedded/:project_id', :to => 'embedded#index' 
    match 'embedded/:project_id/*path', :to => 'embedded#index' , :format => false
    match 'embedded/embed_file/:project_id', :to => 'embedded#embed_file'
  end
else
  class << ActionController::Routing::Routes;self;end.class_eval do
    define_method :clear!, lambda {}
  end
  ActionController::Routing::Routes.draw do |map|
    map.connect 'embedded/:id/*path', :controller => 'embedded', :action => 'index'
  end
end
