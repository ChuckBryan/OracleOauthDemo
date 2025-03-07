using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace OpenIddictDemo.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TestApiController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get()
        {
            return Ok(new
            {
                Message = "This is a protected API",
                User = User.Identity?.Name ?? "Unknown",
                Claims = User.Claims.Select(c => new { c.Type, c.Value })
            });
        }
    }
}