require 'session_wrapper'
ActionController::Base.class_eval{include SessionWrapperHelper; helper SessionWrapperHelper}