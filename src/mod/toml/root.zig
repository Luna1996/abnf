const std = @import("std");

pub const Toml = union(enum) {
  string  : []const u8,
  integer : i64,
  float   : f64,
  boolean : bool,
  datetime: DateTime,
  array   : Array,
  table   : Table,

  const Self = @This();
  
  pub const Parser = @import("plib").Parser(@import("gen").abnf);
  pub const Ast = Parser.Ast;

  pub const Tag = @as(type, std.meta.Tag(Self));

  pub const DateTime = @import("datetime.zig").DateTime;
  pub const Array = std.ArrayListUnmanaged(Self);
  pub const Table = std.StringHashMapUnmanaged(Self);
  
  pub usingnamespace @import("core.zig");
  pub usingnamespace @import("formatter_flat.zig");
  pub usingnamespace @import("formatter_json.zig");
  pub usingnamespace @import("json_to_toml.zig");
};

test "toml" {
  std.debug.print("\n", .{});
  const allocator = std.testing.allocator;
  const dir = std.fs.cwd();
  const name = "../../toml-test/" ++ "valid/spec-example-1" ++ ".toml";
  const file_text = try dir.readFileAlloc(allocator, name, std.math.maxInt(usize));
  defer allocator.free(file_text);
  const real_path = try dir.realpathAlloc(allocator, name);
  defer allocator.free(real_path);
  var toml = try Toml.parse(Toml, .{
    .allocator = allocator,
    .file_path = real_path,
    .input = file_text,
  });
  defer toml.deinit(allocator);
  std.debug.print("{}", .{toml});
}