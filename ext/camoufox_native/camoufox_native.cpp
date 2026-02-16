#include <ruby.h>
#include <cstring>
#include <cstdlib>

namespace {

VALUE pkgman_module() {
  ID camoufox_id = rb_intern("Camoufox");
  if (!rb_const_defined(rb_cObject, camoufox_id)) {
    return Qnil;
  }

  VALUE camoufox_mod = rb_const_get(rb_cObject, camoufox_id);
  ID pkgman_id = rb_intern("Pkgman");
  if (!rb_const_defined(camoufox_mod, pkgman_id)) {
    return Qnil;
  }

  return rb_const_get(camoufox_mod, pkgman_id);
}

VALUE pkgman_default_executable() {
  VALUE pkgman = pkgman_module();
  if (NIL_P(pkgman)) {
    return Qnil;
  }

  return rb_funcall(pkgman, rb_intern("executable_path"), 0);
}

VALUE fetch_executable_path(VALUE rb_options) {
  Check_Type(rb_options, T_HASH);

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

VALUE build_cli_response(const char* command) {
  VALUE pkgman = pkgman_module();

  if (strcmp(command, "path") == 0) {
    if (!NIL_P(pkgman)) {
      VALUE dir = rb_funcall(pkgman, rb_intern("install_dir"), 0);
      if (!NIL_P(dir)) {
        VALUE result = rb_str_dup(dir);
        rb_str_cat_cstr(result, "\n");
        return result;
      }
    }
    return rb_str_new_cstr("(not configured)\n");
  }
  if (strcmp(command, "version") == 0) {
    if (!NIL_P(pkgman)) {
      VALUE ver = rb_funcall(pkgman, rb_intern("version_string"), 0);
      if (!NIL_P(ver)) {
        VALUE result = rb_str_new_cstr("Camoufox ");
        rb_str_append(result, ver);
        rb_str_cat_cstr(result, "\n");
        return result;
      }
    }
    return rb_str_new_cstr("Camoufox not installed\n");
  }
  if (strcmp(command, "fetch") == 0) {
    if (!NIL_P(pkgman)) {
      rb_funcall(pkgman, rb_intern("install"), 0);
      return rb_str_new_cstr("Fetch complete.\n");
    }
    return rb_str_new_cstr("Pkgman not available.\n");
  }
  if (strcmp(command, "remove") == 0) {
    if (!NIL_P(pkgman)) {
      rb_funcall(pkgman, rb_intern("remove"), 0);
      return rb_str_new_cstr("Remove complete.\n");
    }
    return rb_str_new_cstr("Pkgman not available.\n");
  }
  return rb_str_new_cstr("Unknown command.\n");
}

VALUE native_executable_path(VALUE self, VALUE rb_options) {
  return fetch_executable_path(rb_options);
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
  rb_define_module_function(camoufox_module, "executable_path", RUBY_METHOD_FUNC(native_executable_path), 1);
  rb_define_module_function(camoufox_module, "run_cli", RUBY_METHOD_FUNC(native_cli), -1);
}
