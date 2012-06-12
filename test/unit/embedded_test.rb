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

require File.dirname(__FILE__) + '/../test_helper'

class EmbeddedTest < ActiveSupport::TestCase

  def setup
    Setting.plugin_embedded = { 'path' => '/path/to',
                                'index' => 'main.html overview-summary.html index.html',
                                'extensions' => 'html png gif',
                                'template' => 'doxygen',
                                'encoding' => '',
                                'menu' => 'Embedded' }
  end
  
  def test_available_templates
    assert_equal ['doxygen', 'javadoc', 'rcov'], Redmine::Plugins::Embedded.available_templates
  end
  
  def test_assets
    assert_equal ['rcov.css', 'rcov.js'], Redmine::Plugins::Embedded.assets('rcov')
  end
  
  def test_detect_template_from_path
    to_test = { '/path/to/doc' => 'doxygen',
                '/path/to/javadoc/html' => 'javadoc' }
                
    to_test.each { |path, template| assert_equal template, Redmine::Plugins::Embedded.detect_template_from_path(path) }
  end
  
  def test_valid_extension
    to_test = {'index.html' => true,
               'path/to/index.html' => true,
               'path/to/image.png' => true,
               'path/to/something.else' => false}

    to_test.each { |path, expected| assert_equal expected, Redmine::Plugins::Embedded.valid_extension?(path) }
  end
end
