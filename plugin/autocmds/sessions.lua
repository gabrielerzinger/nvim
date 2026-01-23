v.augroup("SessionManagement", {
  {
    event = "VimEnter",
    opts = {
      pattern = "*",
      nested = true,
      callback = function()
        require("v.utils.sessions").load_session_or_dashboard()
      end,
    },
  },
})
