#include <ruby.h>
#include <cstring>
#include <cstdlib>

namespace {

VALUE pkgman_default_executable() {
  ID camoufox_id = rb_intern("Camoufox");
  if (!rb_const_defined(rb_cObject, camoufox_id)) {
    return Qnil;
  }

  VALUE camoufox_module = rb_const_get(rb_cObject, camoufox_id);
  ID pkgman_id = rb_intern("Pkgman");
  if (!rb_const_defined(camoufox_module, pkgman_id)) {
    return Qnil;
  }

  VALUE pkgman_module = rb_const_get(camoufox_module, pkgman_id);
  VALUE install_dir = rb_funcall(pkgman_module, rb_intern("install_dir"), 0);
  if (NIL_P(install_dir)) {
    return Qnil;
  }

  VALUE file_class = rb_const_get(rb_cObject, rb_intern("File"));
  VALUE executable_name = rb_str_new_cstr("camoufox");
  return rb_funcall(file_class, rb_intern("join"), 2, install_dir, executable_name);
}

VALUE fetch_executable_path(VALUE rb_options) {
  ID executable_id = rb_intern("executable_path");
  VALUE executable_key = ID2SYM(executable_id);
  VALUE explicit_value = rb_hash_lookup(rb_options, executable_key);

  if (!NIL_P(explicit_value)) {
    return explicit_value;
  }

  const char* env_value = std::getenv("CAMOUFOX_EXECUTABLE_PATH");
  if (env_value && env_value[0] != '\0') {
    return rb_str_new_cstr(env_value);
  }

  VALUE pkgman_path = pkgman_default_executable();
  if (!NIL_P(pkgman_path)) {
    return pkgman_path;
  }

  return Qnil;
}

VALUE build_stub_launch_options(VALUE rb_options) {
  Check_Type(rb_options, T_HASH);
  VALUE result = rb_hash_new();

  VALUE executable_key = ID2SYM(rb_intern("executable_path"));
  VALUE executable_path = fetch_executable_path(rb_options);
  rb_hash_aset(result, executable_key, executable_path);

  VALUE args = rb_ary_new();
  rb_hash_aset(result, ID2SYM(rb_intern("args")), args);

  VALUE env = rb_hash_new();
  rb_hash_aset(env, rb_str_new_cstr("CAMOU_CONFIG_1"), rb_str_new_cstr("{}"));
  rb_hash_aset(result, ID2SYM(rb_intern("env")), env);

  ID headless_id = rb_intern("headless");
  VALUE headless_key = ID2SYM(headless_id);
  VALUE headless_value = rb_hash_lookup(rb_options, headless_key);

  if (NIL_P(headless_value)) {
    headless_value = Qfalse;
  } else {
    headless_value = RTEST(headless_value) ? Qtrue : Qfalse;
  }

  rb_hash_aset(result, headless_key, headless_value);

  ID user_data_dir_id = rb_intern("user_data_dir");
  VALUE user_data_dir_key = ID2SYM(user_data_dir_id);
  VALUE user_data_dir_value = rb_hash_lookup(rb_options, user_data_dir_key);
  if (!NIL_P(user_data_dir_value)) {
    rb_hash_aset(result, user_data_dir_key, user_data_dir_value);
  }

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
