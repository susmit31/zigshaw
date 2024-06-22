const std = @import("std");
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

pub fn main() !void{
	// Welcome message
	try stdout.writer().print("Welcome to Zigshaw v0.1.0.\n", .{});
	
	// Defining the buffer and the allocator for using in the main loop
	var gpa = std.heap.GeneralPurposeAllocator(.{}){};
	const allocator = gpa.allocator();
	var buffer: [1024]u8 = undefined;

	// Remind the programmer, who most likely has no connection to the outside world, what time and date it is
	var date_child = std.process.Child.init(&[_][]const u8{"date"}, allocator);
	_ = try date_child.spawnAndWait();
	
	// Main loop
	try looper(&buffer, allocator);
}

// Split input command into argv
fn split (str: []const u8) [][]const u8 {
	var splitted_arr: [1024][]const u8 = undefined;

	var iter = std.mem.splitSequence(u8, str, " ");
	var i: usize = 0;

	while (iter.next()) |x| {
		splitted_arr[i] = x;
		i+=1;
	}
	
	return splitted_arr[0..i];
}

fn looper (buffer: *[1024]u8, allocator: std.mem.Allocator) !void{
	var input: []const u8 = undefined;
	var splitted: [][]const u8 = undefined;
	
	while (true){
		// Prompt
		try stdout.writer().print(">> ",.{});

		// Input
		input = (try stdin.reader().readUntilDelimiterOrEof(buffer, '\n')).?;
		if (input.len<1) {
			continue;
		} else if (std.mem.eql(u8, "exit", input) or std.mem.eql(u8, "quit", input)){
			try stdout.writer().print("Goodbye, my friend.\n",.{});
			return;
		} 
		splitted = split(input);

		// Spawn child process
		var child = std.process.Child.init(splitted, allocator);
		_ = child.spawnAndWait() catch |err| {
			std.debug.print("{}\n",.{err});
			continue;		
		};
		//std.debug.print("{}\n",.{output});		
	}
	return;
}
