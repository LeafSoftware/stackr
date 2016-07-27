module Stackr
  class StackMissingError < StandardError; end
  class StackAlreadyExistsError < StandardError; end
  class StackUpdateNotRequiredError < StandardError; end
  class InsufficientCapabilitiesError < StandardError; end
  class TemplateValidationError < StandardError; end
  class MissingParameterError < StandardError; end
  class TemplateTooBigError < StandardError; end
  class MissingTemplateBucketError < StandardError; end
end
