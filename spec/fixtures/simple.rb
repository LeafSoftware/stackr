Stackr::Template.new.tap do |t|

  t.name = 'Simple'
  t.parameter_map = { 'FirstParameter' => 'FIRST_PARAMETER'}

  t.template_dsl = template do
    value AWSTemplateFormatVersion: '2010-09-09'
    value Description: 'Simple Template'
  end
end
