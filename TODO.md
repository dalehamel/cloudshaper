* Allow variables to include arrays natively
 * Detect arrays, and flatten into strings (terraform doesn't support arrays for variable values :sad\_panda:)
+ Improve test coverage
+ Come up with a way to lock S3 states
+ Improve documentation
+ Make module DSL command not a no-op:
 + Module nesting must work!
  + Call generate on nested modules, then just use terraform's module keyword?
 + Strategy to ship modules around
