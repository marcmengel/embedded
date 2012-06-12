require 'redmine'
require 'embedded'

Redmine::Plugin.register :embedded do
  name 'Embedded'
  author 'Jean-Philippe Lang'
  description 'Embed various documentations in your projects'
  version '0.0.1'
  settings :default => { 'path' => '/var/doc/{PROJECT}/html',
                         'index' => 'main.html overview-summary.html index.html',
                         'extensions' => 'html png gif',
                         'template' => '',
                         'encoding' => '',
                         'menu' => 'Embedded' },
           :partial => 'settings/embedded'

  project_module :embedded do
    permission :view_embedded_doc, {:embedded => :index}
  end

  menu :project_menu, :embedded, { :controller => 'embedded', :action => 'index', :path => nil },
                                 :caption => Proc.new { Setting.plugin_embedded['menu'] },
                                 :if => Proc.new { !Setting.plugin_embedded['menu'].blank? }
end

# Routes
class << ActionController::Routing::Routes;self;end.class_eval do
  define_method :clear!, lambda {}
end

ActionController::Routing::Routes.draw do |map|
  map.connect 'embedded/:id/*path', :controller => 'embedded', :action => 'index'
end
