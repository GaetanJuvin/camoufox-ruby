#include <ruby.h>
#include <cstring>

namespace {

VALUE build_stub_launch_options(VALUE rb_options) {
  VALUE result = rb_hash_new();

  VALUE executable_path = rb_str_new_cstr("/usr/local/bin/camoufox");
  rb_hash_aset(result, ID2SYM(rb_intern("executable_path")), executable_path);

  VALUE args = rb_ary_new();
  rb_hash_aset(result, ID2SYM(rb_intern("args")), args);

  VALUE env = rb_hash_new();
  rb_hash_aset(env, rb_str_new_cstr("CAMOU_CONFIG_1"), rb_str_new_cstr("{}"));
  rb_hash_aset(result, ID2SYM(rb_intern("env")), env);

  rb_hash_aset(result, ID2SYM(rb_intern("headless")), Qfalse);

  return result;
}

VALUE build_cli_response(const char* command) {
  if (strcmp(command, "path") == 0) {
    return rb_str_new_cstr("/usr/local/share/camoufox\n");
  }
  if (strcmp(command, "version") == 0) {
    return rb_str_new_cstr("Camoufox native stub v0.0.1\n");
  }
  if (strcmp(command, "fetch") == 0) {
    return rb_str_new_cstr("Fetch command is not yet implemented in the native port.\n");
  }
  if (strcmp(command, "remove") == 0) {
    return rb_str_new_cstr("Remove command is not yet implemented in the native port.\n");
  }
  return rb_str_new_cstr("Unknown command.\n");
}

VALUE native_launch_options(VALUE self, VALUE rb_options) {
  return build_stub_launch_options(rb_options);
}

VALUE native_cli(int argc, VALUE* argv, VALUE self) {
  if (argc < 1) {
    rb_raise(rb_eArgError, "command required");
  }
  VALUE command_val = argv[0];
  Check_Type(command_val, T_STRING);
  const char* command = StringValueCStr(command_val);
  return build_cli_response(command);
}

} // namespace

extern "C" void Init_camoufox_native() {
  VALUE camoufox_module = rb_define_module("CamoufoxNative");
  rb_define_module_function(camoufox_module, "launch_options", RUBY_METHOD_FUNC(native_launch_options), 1);
  rb_define_module_function(camoufox_module, "run_cli", RUBY_METHOD_FUNC(native_cli), -1);
}
