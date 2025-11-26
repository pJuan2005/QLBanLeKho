using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;


namespace Model
{
    public class PromotionsModel
    {
        public int PromotionID { get; set; }
        public string? PromotionName { get; set; }
        public string? Type { get; set; }
        public decimal Value { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int CategoryID { get; set; }
        public string? Status { get; set; }
    }
}
