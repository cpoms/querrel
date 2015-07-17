$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "logger"
require "active_record"
require "querrel"
require "models"
require "active_record_config"
require "querrel_test_class"