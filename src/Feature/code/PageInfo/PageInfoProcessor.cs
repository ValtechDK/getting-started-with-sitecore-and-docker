using Sitecore;
using Sitecore.Pipelines.HttpRequest;

namespace Feature.PageInfo
{
    public class PageInfoProcessor : HttpRequestProcessor
    {
        public override void Process(HttpRequestArgs args)
        {
            if (args.Aborted || Context.Item == null)
            {
                return;
            }

            args.HttpContext.Response.Headers["X-Sitecore-Item"] = Context.Item.Uri.ToString();
        }
    }
}