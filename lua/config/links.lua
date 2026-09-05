-- Bookmarks opened with <leader>o. Add your own lines here; nothing else needs changing.
local M = {}

M.links = {
  ["Notion — TASKS"] = "https://app.notion.com/p/TASKS-3c931ce6ccfa80d8b2fff17d02bbf0cc",
  ["Django docs"] = "https://docs.djangoproject.com/en/stable/",
  ["Django REST Framework"] = "https://www.django-rest-framework.org/",
  ["FastAPI docs"] = "https://fastapi.tiangolo.com/",
  ["Ruff rules"] = "https://docs.astral.sh/ruff/rules/",
  ["uv docs"] = "https://docs.astral.sh/uv/",
  ["GitHub"] = "https://github.com/",
  ["Local server"] = "http://localhost:8000",
}

function M.pick()
  local names = vim.tbl_keys(M.links)
  table.sort(names)
  require("fzf-lua").fzf_exec(names, {
    prompt = "Open> ",
    actions = {
      ["default"] = function(selected)
        local url = M.links[selected[1]]
        if url then
          vim.ui.open(url)
        end
      end,
    },
  })
end

return M
