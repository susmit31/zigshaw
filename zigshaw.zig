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

// Split input command into argv with the standard library
// Caveat: doesn't know of quotes
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

// My own splitter. Recognizes opening and closing quotes.
fn split2 (str: []const u8) [][]const u8 {
	var splitted_arr: [1024][]const u8 = undefined;

	var curr_start: usize = 0;
	var curr_loc: usize = 0;
	var i: usize = 0;
	var closed_quotes: bool = true;

	while (curr_loc < str.len) : (curr_loc += 1) {
		if (std.mem.eql(u8, str[curr_loc..curr_loc+1], " ")) {
			if (closed_quotes) {
				splitted_arr[i] = str[curr_start..curr_loc];
				curr_start = curr_loc + 1;
				i += 1;
			}
		} else if (std.mem.eql(u8, str[curr_loc..curr_loc+1], "\"")) {
			closed_quotes = !closed_quotes;
		}
	}

	splitted_arr[i] = str[curr_start..curr_loc];
	i+=1;

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
		splitted = split2(input);
		
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
