#include "jober.h"

Jober::Jober(std::function<void (void*)>& job, RedisMeta* meta):job(job),meta(meta)
{

}

void Jober::run()
{
    job(meta);
}
