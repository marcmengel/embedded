# Redmine - project management software
# Copyright (C) 2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'iconv'

class EmbeddedController < ApplicationController
  class EmbeddedControllerError < StandardError; end
  
  unloadable
  layout 'base'
  before_filter :find_project, :authorize
  
  def index
    path = get_real_path(params[:path])
    if File.directory?(path)
      file = get_index_file(path)
      target = params[:path] || []
      target << file
      # Forces redirect to the index file when the requested path is a directory
      # so that relative links in embedded html pages work
      redirect_to :path => target
      return
    end
    
    # Check file extension
    raise EmbeddedControllerError.new('This file can not be viewed (invalid extension).') unless Redmine::Plugins::Embedded.valid_extension?(path)
    
    if Redmine::MimeType.is_type?('image', path)
      send_file path, :disposition => 'inline', :type => Redmine::MimeType.of(path)
    else
      embed_file path
    end
    
  rescue Errno::ENOENT => e
    # File was not found
    render_404
  rescue Errno::EACCES => e
    # Can not read the file
    render_error "Unable to read the file: #{e.message}"
  rescue EmbeddedControllerError => e
    render_error e.message
  end
  
  private
  
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  # Return the path to the html root directory for the current project
  def get_project_directory
    @project_directory ||= Setting.plugin_embedded['path'].to_s.gsub('{PROJECT}', @project.identifier)
  end
  
  # Returns the absolute path of the requested file
  # Parameter is an Array
  def get_real_path(path)
    real = get_project_directory
    real = File.join(real, path) unless path.nil? || path.empty?
    dir = File.expand_path(get_project_directory)
    real = File.expand_path(real)
    raise Errno::ENOENT unless real.starts_with?(dir) && File.exist?(real)
    real
  end
  
  # Returns the index file in the given directory
  # and raises an exception if none is found
  def get_index_file(dir)
    indexes = Setting.plugin_embedded['index'].to_s.split
    file = indexes.find {|f| File.exist?(File.join(dir, f))}
    raise EmbeddedControllerError.new("No index file found in #{dir} (#{indexes.join(', ')}).") if file.nil?
    file
  end
  
  # Renders a given HTML file
  def embed_file(path)
    @content = File.read(path)
    
    # Extract html title from embedded page
    if @content =~ %r{<title>([^<]*)</title>}mi
      @title = $1.strip
    end
    
    # Keep html body only
    @content.gsub!(%r{^.*<body[^>]*>(.*)</body>.*$}mi, '\\1')
    
    # Re-encode content if needed
    source_encoding = Setting.plugin_embedded['encoding'].to_s
    unless source_encoding.blank?
      begin; @content = Iconv.new('UTF-8', source_encoding).iconv(@content); rescue; end
    end
    
    @doc_template = Redmine::Plugins::Embedded.detect_template_from_path(path)
    render :action => 'index'
  end
end
