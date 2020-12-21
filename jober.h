#ifndef JOBER_H
#define JOBER_H

#include <QRunnable>
#include "redisadapter.h"

class Jober : public QRunnable
{

public:
    explicit Jober(std::function<void (void*)>& job, RedisMeta *meta);

    void run();

private:
    std::function<void (void*)> job;
    RedisMeta* meta;
};

#endif // JOBER_H
