{
  'Mappings' => {
    'EnvironmentMap' => {
      # In your template, use find_in_env('VpcId').
      # It will use the Environment parameter to determine
      # which VpcId to return.
      dev: {
        # VpcId: '' # Your Dev VPC
      },
      test: {
        # VpcId: '' # Your Test VPC
      }
    }
  }
}
