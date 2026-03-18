#include <iostream>
#include "flann_matcher.h"
#include "flann_factory.h"
#include "opencv2/core/hal/interface.h"
#include "opencv2/core/types.hpp"


phg::FlannMatcher::FlannMatcher()
{
    // параметры для приближенного поиска
   index_params = flannKdTreeIndexParams(4);
   search_params = flannKsTreeSearchParams(32);
}

void phg::FlannMatcher::train(const cv::Mat &train_desc)
{
    flann_index = flannKdTreeIndex(train_desc, index_params);
}

void phg::FlannMatcher::knnMatch(const cv::Mat &query_desc, std::vector<std::vector<cv::DMatch>> &matches, int k) const
{
    cv::Mat indices(query_desc.rows, k, CV_32SC1);
    cv::Mat distances2(query_desc.rows, k, CV_32FC1);

    flann_index->knnSearch(
        query_desc,
        indices,
        distances2,
        k,
        *search_params
    );

    matches.resize(query_desc.rows);
    for (size_t rowIdx = 0; rowIdx < query_desc.rows; rowIdx++) {
        for (size_t idx = 0; idx < k; idx++) {
            matches[rowIdx].emplace_back(
                rowIdx,
                indices.at<int>(rowIdx, idx),
                distances2.at<float>(rowIdx, idx)
            );
        }
    }
}
