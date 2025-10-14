﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IGoodsIssuesRepository
    {
        GoodsIssuesModel GetDatabyID(int id);
        bool Create(GoodsIssuesModel model);
        bool Update(GoodsIssuesModel model);
        bool Delete(GoodsIssuesModel model);
    }
}
