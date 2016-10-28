module Stackr
  class StackMissingError < StandardError; end
  class StackAlreadyExistsError < StandardError; end
  class StackUpdateNotRequiredError < StandardError; end
  class InsufficientCapabilitiesError < StandardError; end
  class TemplateValidationError < StandardError; end
  class ParameterMissingError < StandardError; end
  class TemplateTooBigError < StandardError; end
  class TemplateMissingBucketError < StandardError; end
  class StackNameMissingError < StandardError; end
  class ChangeSetMissingError < StandardError; end
end
