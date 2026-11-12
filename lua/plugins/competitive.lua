-- Competitive programming: receive problems/contests from the Competitive Companion
-- browser extension, then compile and run every sample test with one key.
--
-- Workflow on Codeforces:
--   1. <leader>tc   (Neovim starts listening on port 27121)
--   2. Open the contest page in the browser, click the Competitive Companion icon.
--   3. Every problem lands in ~/codeforces/<contest id>/A.cpp, B.cpp, ... with its
--      sample tests in tests/, pre-filled from templates/cp.cpp.
--   4. <leader>tr   compile with g++ and diff your output against every sample.
--
-- Contest ids and problem letters are parsed from the problem URL rather than the
-- title, so "A. Watermelon" becomes A.cpp instead of "A. Watermelon.cpp".

local CP_ROOT = vim.fn.expand("~/cp")

local function sanitize(s)
  return (s:gsub("[^%w%-_]+", "_"):gsub("^_+", ""):gsub("_+$", ""))
end

-- Returns judge, contest, problem for a Competitive Companion task.
local function parse_task(task)
  local url = task.url or ""
  -- codeforces.com/contest/2050/problem/A, /gym/104/problem/B, /problemset/problem/4/A
  local contest, problem = url:match("codeforces%.com/contest/(%d+)/problem/(%w+)")
  if not contest then
    contest, problem = url:match("codeforces%.com/gym/(%d+)/problem/(%w+)")
    if contest then contest = "gym" .. contest end
  end
  if not contest then
    contest, problem = url:match("codeforces%.com/problemset/problem/(%d+)/(%w+)")
  end
  if contest then
    return "codeforces", contest, problem
  end
  -- Other judges: "AtCoder - ABC 300" -> atcoder / ABC_300, title -> file name.
  local judge, group = (task.group or ""):match("^%s*(.-)%s*%-%s*(.-)%s*$")
  judge = sanitize((judge ~= "" and judge or task.group or "misc"):lower())
  group = sanitize(group ~= nil and group ~= "" and group or "single")
  return judge, group, sanitize(task.name or "problem")
end

local function contest_dir(task)
  local judge, contest = parse_task(task)
  -- Codeforces goes next to your existing contests in ~/codeforces.
  if judge == "codeforces" then
    return ("%s/%s"):format(vim.fn.expand("~/codeforces"), contest)
  end
  return ("%s/%s/%s"):format(CP_ROOT, judge, contest)
end

local function problem_file(task, ext)
  local _, _, problem = parse_task(task)
  return problem .. "." .. ext
end

local function cmd(c) return "<cmd>CompetiTest " .. c .. "<cr>" end

return {
  {
    "xeluxee/competitest.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CompetiTest",
    opts = {
      -- Same flags as <leader>r, so local runs and test runs behave identically.
      -- -DLOCAL lets you guard debug prints with #ifdef LOCAL.
      compile_command = {
        cpp = {
          exec = "g++",
          args = { "-std=c++23", "-O2", "-Wall", "-Wextra", "-Wshadow", "-DLOCAL", "$(FNAME)", "-o", "$(FNOEXT)" },
        },
        c = { exec = "gcc", args = { "-std=c17", "-O2", "-Wall", "-Wextra", "-DLOCAL", "$(FNAME)", "-o", "$(FNOEXT)" } },
      },
      run_command = {
        cpp = { exec = "./$(FNOEXT)" },
        c = { exec = "./$(FNOEXT)" },
        python = { exec = "python3", args = { "$(FNAME)" } },
      },
      maximum_time = 3000, -- ms; generous enough for -O2 C++, catches infinite loops
      output_compare_method = "squish", -- ignore trailing whitespace / extra newlines
      view_output_diff = true,

      -- Keep the contest folder tidy: sample tests go in tests/A_input0.txt etc.
      testcases_directory = "tests",

      runner_ui = { interface = "popup" },
      popup_ui = { total_width = 0.85, total_height = 0.85 },

      template_file = { cpp = vim.fn.stdpath("config") .. "/templates/cp.cpp" },
      evaluate_template_modifiers = true, -- fills $(PROBLEM), $(URL), $(DATE) in the template
      date_format = "%Y-%m-%d %H:%M",

      received_files_extension = "cpp",
      received_problems_path = function(task, ext)
        return contest_dir(task) .. "/" .. problem_file(task, ext)
      end,
      received_problems_prompt_path = false,
      received_contests_directory = function(task)
        return contest_dir(task)
      end,
      received_contests_problems_path = function(task, ext)
        return problem_file(task, ext)
      end,
      received_contests_prompt_directory = false,
      received_contests_prompt_extension = false,
      open_received_problems = true,
      open_received_contests = true,
    },
    keys = {
      { "<leader>tc", cmd("receive contest"), desc = "Receive contest (browser)" },
      { "<leader>tp", cmd("receive problem"), desc = "Receive problem (browser)" },
      { "<leader>tT", cmd("receive testcases"), desc = "Receive tests into this file" },
      { "<leader>tP", cmd("receive persistently"), desc = "Listen for browser continuously" },
      { "<leader>tS", cmd("receive stop"), desc = "Stop listening" },
      { "<leader>tr", cmd("run"), desc = "Compile & run all tests" },
      { "<leader>tR", cmd("run_no_compile"), desc = "Run tests (no recompile)" },
      { "<leader>tu", cmd("show_ui"), desc = "Reopen test results" },
      { "<leader>ta", cmd("add_testcase"), desc = "Add testcase" },
      { "<leader>te", cmd("edit_testcase"), desc = "Edit testcase" },
      { "<leader>td", cmd("delete_testcase"), desc = "Delete testcase" },
      {
        "<leader>tn",
        function()
          -- Fresh scratch solution from the template, for practice outside a contest.
          local dir = CP_ROOT .. "/scratch"
          vim.fn.mkdir(dir, "p")
          local path = ("%s/%s.cpp"):format(dir, os.date("%Y%m%d_%H%M%S"))
          vim.cmd.edit(vim.fn.fnameescape(path))
          local tpl = vim.fn.stdpath("config") .. "/templates/cp.cpp"
          if vim.fn.filereadable(tpl) == 1 then
            local lines = vim.tbl_map(function(l)
              return (l:gsub("%$%(%u+%)", ""))
            end, vim.fn.readfile(tpl))
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
          end
        end,
        desc = "New scratch solution",
      },
      { "<leader>tf", function() require("fzf-lua").files({ cwd = CP_ROOT }) end, desc = "Find CP file" },
    },
  },
}
