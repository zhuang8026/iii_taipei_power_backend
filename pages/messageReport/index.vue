<template>
  <div class="message-report">
    <w-layout>
      <template #header-text>簡訊記錄</template>
      <template #filter>
        <el-form ref="searchBox" :model="searchBox">
          <el-form-item label="查詢區間：">
            <el-col :span="11">
              <el-date-picker
                type="month"
                placeholder="請選擇月份"
                v-model="searchBox.date1"
                style="width: 100%;"
                format="yyyy/MM"
                :editable="false"
              ></el-date-picker>
            </el-col>
            <el-col class="line" :span="2">至</el-col>
            <el-col :span="11">
              <el-date-picker
                type="month"
                placeholder="請選擇月份"
                v-model="searchBox.date2"
                style="width: 100%;"
                format="yyyy/MM"
                :editable="false"
              ></el-date-picker>
            </el-col>
          </el-form-item>
          <el-form-item class="btn-list">
            <el-button>查詢</el-button>
            <el-button>下載</el-button>
          </el-form-item>
        </el-form>
      </template>

      <div class="container">
        <el-table :data="tableData" stripe style="width: 100%;">
          <el-table-column prop="name" label="姓名" width="120">
          </el-table-column>
          <el-table-column prop="email" label="電子郵件" width="345" sortable>
          </el-table-column>
          <el-table-column prop="Jan" label="一月" width="95" sortable>
            <template slot-scope="scope">
              <img :src="require(`@/assets/img/common/${scope.row.Jan}`)" />
            </template>
          </el-table-column>
          <el-table-column prop="Feb" label="二月" width="95" sortable>
            <template slot-scope="scope">
              <img :src="require(`@/assets/img/common/${scope.row.Feb}`)" />
            </template>
          </el-table-column>
          <el-table-column prop="Mar" label="三月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="Apr" label="四月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="May" label="五月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="Jun" label="六月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="Jul" label="七月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="Aug" label="八月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="Sep" label="九月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="Oct" label="十月" width="95" sortable>
          </el-table-column>
          <el-table-column prop="Nov" label="十一月" width="131" sortable>
          </el-table-column>
          <el-table-column prop="Dec" label="十二月" sortable width="131">
            <!-- <template slot-scope="scope">
              <img :src="require(`@/assets/img/common/${scope.row.Dec}`)" />
            </template> -->
          </el-table-column>
        </el-table>
        <el-pagination background layout="prev, pager, next" :total="1">
        </el-pagination>
      </div>
    </w-layout>
  </div>
</template>
<script>
import WLayout from '@/components/Layout';

export default {
  components: {
    WLayout,
  },
  data() {
    return {
      searchBox: {
        date1: '',
        date2: '',
        text: '',
      },
      tableData: [
        {
          name: '王一明',
          email: 'aaaaaaaaaaaaa@hotmail.com',
          Jan: 'icon-check-circle.svg',
          Feb: 'icon-check-circle.svg',
          Mar: '',
          Apr: '',
          May: '',
          Jun: '',
          Jul: '',
          Aug: '',
          Sep: '',
          Oct: '',
          Nov: '',
          Dec: '',
        },
        {
          name: '王一明',
          email: 'aaaaaaaaaaaaa@hotmail.com',
          Jan: 'icon-check-circle.svg',
          Feb: 'icon-check-circle.svg',
          Mar: '',
          Apr: '',
          May: '',
          Jun: '',
          Jul: '',
          Aug: '',
          Sep: '',
          Oct: '',
          Nov: '',
          Dec: '',
        },
        {
          name: '王一明',
          email: 'aaaaaaaaaaaaa@hotmail.com',
          Jan: 'icon-check-circle.svg',
          Feb: 'icon-check-circle.svg',
          Mar: '',
          Apr: '',
          May: '',
          Jun: '',
          Jul: '',
          Aug: '',
          Sep: '',
          Oct: '',
          Nov: '',
          Dec: '',
        },
        {
          name: '王一明',
          email: 'aaaaaaaaaaaaa@hotmail.com',
          Jan: 'icon-check-circle.svg',
          Feb: 'icon-check-circle.svg',
          Mar: '',
          Apr: '',
          May: '',
          Jun: '',
          Jul: '',
          Aug: '',
          Sep: '',
          Oct: '',
          Nov: '',
          Dec: '',
        },
        {
          name: '王一明',
          email: 'aaaaaaaaaaaaa@hotmail.com',
          Jan: 'icon-check-circle.svg',
          Feb: 'icon-check-circle.svg',
          Mar: '',
          Apr: '',
          May: '',
          Jun: '',
          Jul: '',
          Aug: '',
          Sep: '',
          Oct: '',
          Nov: '',
          Dec: '',
        },
      ],
    };
  },
  methods: {},
};
</script>
<style lang="scss" scoped>
.message-report {
  /** el form 樣式 */
  /deep/ .el-form {
    display: flex;

    .el-form-item {
      display: flex;
      align-items: center;
      margin-right: 1rem;
    }

    .btn-list {
      margin-right: 0;
    }

    .el-form-item__content {
      display: flex;
      align-items: center;
    }

    .el-col-2 {
      color: #333;
      font-weight: bolder;
      font-size: 1.125rem;
      font-family: Noto Sans CJK TC, sans-serif;
      text-align: center;
    }
  }

  /** el table 樣式 */
  /deep/ .el-table {
    border: 1px solid #b5b5b5;

    .cell {
      padding-right: 1rem;
      padding-left: 1rem;
    }

    th:first-child .cell {
      padding-left: 1.75rem;
    }

    th.is-leaf {
      border-bottom: 0.0925rem solid #707070;
      border-left: 0.0625rem solid #b5b5b5;
    }

    th:first-child {
      border-left: unset;
    }

    td {
      padding: 0.625rem 0;
      border-left: 0.0625rem solid #b5b5b5;

      &:first-child {
        border-left: unset;
      }

      .cell {
        color: #787878;
        font-size: 1rem;
        font-family: Noto Sans CJK TC, sans-serif;
        letter-spacing: 0.15rem;

        img {
          display: block;
          margin: auto;
        }
      }
    }

    td:first-child .cell {
      padding-left: 1.75rem;
    }
  }

  /** el pagination */
  /deep/ .el-pager li {
    min-width: 2.175rem;
    height: 2.2rem;
    padding: 0 0.6rem;
    line-height: 2.2rem;
  }

  /deep/ .el-pagination button {
    min-width: 2.175rem;
    height: 2.2rem;
    line-height: 2.2rem;
  }
}

@media screen and (max-width: 1500px) {
  .message-report {
    /deep/ .filter-bar {
      flex-direction: column;
      align-items: flex-start;
    }
  }
}

@media screen and (max-width: 1289px) {
  .message-report {
    .el-form {
      flex-wrap: wrap;
      margin-top: 0.2rem;

      .btn-list {
        margin-top: 1rem;
      }
    }
  }
}
</style>
<style lang="scss">

.el-date-picker {
  width: 17.425rem;
}

.el-date-picker .el-picker-panel__content {
  width: 15.25rem;
  margin: 1rem;
}

 </style>
